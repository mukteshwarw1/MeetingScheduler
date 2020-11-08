class VideoMeeting < ApplicationRecord

	before_create :generate_unique_url
	before_create :generate_pass

	belongs_to :meeting, class_name: 'Meeting',  foreign_key: 'meeting_id'


	private

	def generate_unique_url
	  begin
	    self.link_url = "http://localhost:3000/videoconf-#{SecureRandom.hex[0,Time.now.to_i]}"
	  end while self.class.exists?(link_url: link_url)
	end

	def generate_pass
	  begin
	    self.password = "#{rand.to_s[2..7]}"
	  end while self.class.exists?(password: password)
	end

end
