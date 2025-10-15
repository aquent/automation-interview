require 'cgi'
require 'modularity'
require 'uri'

module UrlUtil

  SERVER_HOST = ENV['SERVER_HOST']
  SERVER_PORT = ENV['SERVER_PORT'] ? ENV['SERVER_PORT'].to_i : URI::HTTPS::DEFAULT_PORT
  API_PORT = ENV['API_PORT']
  PROC_PARAM = 'PROC'

  as_trait do |context, servlet, domain|

    define_method :url do |path = '', query = {}|
      base_url context + (servlet || '') + path, query
    end

    define_method :proc_url do |proc, query = {}|
      query[PROC_PARAM] = proc
      url '', query
    end if servlet

    define_method :base_url do |path = '', query = {}|
      UrlUtil.base_url path, query, domain
    end if domain

  end

  def get_url_for_page(page, *params)
    query = {}
    if params.last.is_a? Hash
      query = params.delete_at -1
    end
    page_url = page
    if page.is_a?(Class) && page < BasePage
      if params && params != [] && page.const_defined?(:OPEN_PATH)
        page_url = url (page.const_get(:OPEN_PATH) % params), query
      elsif page.const_defined? :PATH
        page_url = url page.const_get(:PATH), query
      elsif page.const_defined? :BASE_PATH
        domain = page.const_defined?(:DOMAIN) ? page.const_get(:DOMAIN) : nil
        page_url = UrlUtil.base_url page.const_get(:BASE_PATH), query, domain
      elsif page.const_defined? :PROC_NAME
        page_url = proc_url page.const_get(:PROC_NAME), query
      end
    end
    page_url
  end

  # Visits a URL or page.
  # If passed a page class, URL determined from from constants in the following order:
  #   :OPEN_PATH
  #   :PATH
  #   :BASE_PATH
  #   :PROC_NAME
  #
  # @param page [String, Class < BasePage] the URL or page class
  # @param params [*String] parameters to format :OPEN_PATH with
  def visit(page, *params)
    page_url = get_url_for_page page, *params
    @driver.get page_url
    @driver.update_frames
    # todo if writing tests for notification popups will need a way not to execute the following line
    top_page.hide_all_notifications if top_page.is_a? CloudWall::Frameset
    page_url
  end

  def base_url(path = '', query = {})
    UrlUtil.base_url path, query
  end

  def self.base_url(path, query = {}, domain = nil)
    opts = UrlUtil.setup_base_url(domain, SERVER_PORT, query, path)
    URI::HTTPS.build(opts).to_s
  end

  def api_base_url(path, query = {})
    UrlUtil.api_base_url path, query
  end

  def self.api_base_url(path, query = {}, domain = nil)
    port = SERVER_PORT
    use_https = true
    if (API_PORT)
      port = API_PORT
      use_https = false
    end
    opts = UrlUtil.setup_base_url(domain, port, query, path)
    if (use_https)
      URI::HTTPS.build(opts).to_s
    else
      URI::HTTP.build(opts).to_s
    end
  end

  def self.setup_base_url(domain, port, query, path)
    opts = {host: SERVER_HOST, port: port, path: path}
    if domain
      if domain.include? ':'
        opts[:host] = domain[0..domain.index(':') - 1]
        opts[:port] = domain[domain.index(':') + 1..-1]
      else
        opts[:host] = domain % ENV['MAC_DOMAIN']
        opts[:port] = URI::HTTPS::DEFAULT_PORT
      end
    end
    if query.key? :http_user
      userinfo = query.delete(:http_user) + (query.key?(:http_pass) ? ':' + query.delete(:http_pass) : '')
      opts[:userinfo] = URI.escape userinfo
    end
    opts[:fragment] = query.delete(:'#') if query.key? :'#'
    opts[:query] = query.empty? ? nil : URI.encode_www_form(query)
    opts
  end

  def self.parse_query(query)
    hash = {}
    CGI.parse(query).each do |key, value|
      hash[key.to_sym] = value.length > 1 ? value : value[0]
    end unless query.nil?
    hash
  end
end
