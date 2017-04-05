require 'net/http'
require 'json'

Puppet::Type.type(:chronos_job).provide(:chronos_job) do
  def exists?
    content_json = JSON.parse(resource[:content])

    uri = URI("#{resource[:chronos_url]}#{api_version}/scheduler/jobs")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.code == '200'
      jobs = JSON.parse(response.body)

      cleaned_jobs = jobs.map { |job| clean_job(content_json, job) }
      clean_content = clean_job(content_json, content_json)

      cleaned_jobs.include? clean_content
    else
      warning("Could not contact chronos: #{response.code} #{response.body}")
      false
    end
  rescue IOError => e
    warning("Could not contact chronos: #{e.message}")
    false
  end

  def create
    uri = URI("#{resource[:chronos_url]}#{api_version}/scheduler/iso8601")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/json'})
    request.body = resource[:content]

    response = http.request(request)
    if response.code.to_i >= 400 and not resource[:ignore_failures]
      fail("Could not create Chronos job: #{response.code} #{response.body}")
    end
  rescue IOError => e
    warning("Could not contact chronos: #{e.message}. Ignoring since ignore_failures is set")
    raise e unless resource[:ignore_failures]
  end

  def destroy
    content_json = JSON.parse(resource[:content])
    uri = URI("#{resource[:chronos_url]}#{api_version}/scheduler/job/#{content_json['name']}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Delete.new(uri.request_uri, {'Content-Type' =>'application/json'})

    make_request(http, request)
  end

  private

  def make_request(http, request)
    response = http.request(request)
    if response.code.to_i >= 400 and not resource[:ignore_failures]
      fail("Could not contact chronos: #{response.code} #{response.body}")
    end
  rescue IOError => e
    warning("Could not contact chronos: #{e.message}. Ignoring since ignore_failures is set")
    raise e unless resource[:ignore_failures]
  end

  def clean_job(reference_job, job)
    job
        .select { |k, _| reference_job.keys.include?(k) }
        .map { |k, v| { k => (k == 'schedule' ? v.split('/').last : v) } }
        .reduce({}, :merge)
  end

  def api_version
    resource[:api_version].nil? || resource[:api_version].empty? ? '' : "/#{resource[:api_version]}"
  end
end