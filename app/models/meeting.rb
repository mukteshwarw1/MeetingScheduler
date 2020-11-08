class Meeting < ApplicationRecord

	has_many :video_meeting, dependent: :destroy	
	validates :meeting_date, presence: true#, format: { with: /(\d{1,2}[-\/]\d{1,2}[-\/]\d{4})/, message: "invalid date" }
	validates :meeting_time, presence: true
	validates :meeting_type, inclusion: { in: ['video', 'phone' , 'in person'], message: "not a valid meeting type" }

end