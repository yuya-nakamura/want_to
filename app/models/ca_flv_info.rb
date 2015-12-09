# Cache flv_info
class CaFlvInfo < ActiveRecord::Base
  def check_flv_info(video_id)
    flv_info = CaFlvInfo.find_by(smid: video_id)
    if flv_info.nil?
      cookie = login_nicovideo(ENV['NICOADD'], ENV['NICOPASS'])
      response = get_flv_info(cookie, video_id)
      logger.info response
      if !response.key? :closed
        cache = CaFlvInfo.new(
          smid: video_id, ms: response[:ms], thread_id: response[:thread_id],
          deleted: response[:deleted], error: response[:error])
        cache.save
        return cache
      end
    end
    return flv_info
  end

  private

  def login_nicovideo(mail, pass)
    host = 'secure.nicovideo.jp'
    path = '/secure/login?site=niconico'
    body = "mail=#{mail}&password=#{pass}"

    https = Net::HTTP.new(host, 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = https.start do |h|
      h.post(path, body)
    end

    cookie = ''
    response['set-cookie'].split('; ').each do |st|
      idx = st.index('user_session_')
      if idx
        cookie = "user_session=#{st[idx..-1]}"
        break
      end
    end
    return cookie
  end

  def get_flv_info(cookie, video_id)
    host = 'flapi.nicovideo.jp'
    path = "/api/getflv/#{video_id}"

    response = Net::HTTP.new(host).start do |http|
      request = Net::HTTP::Get.new(path)
      request['cookie'] = cookie
      http.request(request)
    end

    flv_info = {}
    response.body.split('&').each do |st|
      stt = st.split('=')
      flv_info[stt[0].to_sym] = stt[1]
    end

    return flv_info
  end
end
