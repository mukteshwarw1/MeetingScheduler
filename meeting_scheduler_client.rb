
#Meeting scheduler
#Accessed from the rails console to manage meetings.

class MeetingSchedulerCLI

	def choose_user
		puts""
		#user = tp User.all
		prompt = "TO BEGIN PLEASE TYPE YOUR USER ID: "
		user_id = get_valid_user (prompt)
		@user = User.find user_id
		puts "Hello #{@user.name}, welcome to the Rails console meeting scheduler!"
	end

	def get_valid_user(prompt)
		#tp User.allsql = "SELECT meetings.id, meetings.title"
		sql = "SELECT id, name, email from users"
		tp ActiveRecord::Base.connection.execute(sql)
		puts ""
		loop do
		  print prompt
		  user_id = gets.chomp
		  if(User.where(id:user_id).empty?)
			puts "PLEASE ENTER VALID USER ID AS SHOWN IN ABOVE TABLE"
		  else
		  	return user_id
		  end
		end
	end

	def get_valid_meeting(prompt)

		sql = "SELECT meetings.id, meetings.title, meetings.meeting_type, meetings.meeting_date, meetings.meeting_time, (select name from users where id=meetings.creator) as 'Meeting Creator', 
		(select name from users where id=meetings.participant) as 'Meeting Participant', video_meetings.link_url  FROM meetings LEFT JOIN video_meetings ON video_meetings.meeting_id = meetings.id LEFT JOIN users ON users.id = meetings.creator"


		tp ActiveRecord::Base.connection.execute(sql)

		puts " "
		loop do
		  print prompt
		  meeting_id = gets.chomp
		  if(Meeting.where(id:meeting_id).empty?)
			puts "PLEASE ENTER VALID MEETING ID AS SHOWN IN ABOVE TABLE"
		  else
		  	return meeting_id
		  end
		end
	end


	def get_valid_meeting_type
		meeting_type = ['video', 'phone' , 'in person']
	  	loop do
		  print 'Type: '
		  type = gets.chomp
		  if(meeting_type.include? type.downcase)
		  	return type.downcase
		  else
		  	puts "Please enter valid meeting type - Video, Phone, In person"
		  end	
		end
	end

	def get_valid_meeting_title
	  	loop do
		  print 'Title: '
		  title = gets.chomp
		  if(!title.empty?)
		  	return title
		  else
		  	puts "Please enter valid title"
		  end	
		end
	end

	def get_valid_date
		loop do
		  print 'Date: '
		  date = gets.chomp
		  is_valid_format = date.match(/(\d{1,2}[-\/]\d{1,2}[-\/]\d{4})/)
	  	  parseable = Date.strptime(date, '%d/%m/%Y') rescue false
		  if(is_valid_format && parseable)
		  	return date
		  else
		  	puts "Please enter valid date DD/MM/YYYY"
		  end	
		end
	end
	

	def get_valid_time
		loop do
		  print 'Time: '
		  time = gets.chomp
		  is_valid_format = time.match(/^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/)
		  if(is_valid_format)
		  	return time
		  else
		  	puts "Please enter valid time in 24 hrs format e.g. 10:30"
		  end	
		end
	end


	def new_meeting

		meeting = Meeting.new

		puts ""
		puts "***CREATE A MEETING***"

	  	meeting.title = get_valid_meeting_title
	  	meeting.meeting_type = get_valid_meeting_type
	  	meeting.meeting_date = get_valid_date
		meeting.meeting_time = get_valid_time
		meeting.creator = @user.id

		
		prompt = "Participant (please type participant user id) :"
		meeting.participant = get_valid_user(prompt)

		print "Please press ENTER to save the meeting:"
		gets.chomp	

		if(meeting.save)
			puts "Meeting saved successfully!"
			puts "================================================================="

			#Meeting video unique URL sames in table with password
			if(meeting.meeting_type=='video')
				video = VideoMeeting.new(meeting_id: meeting.id, status: 'active')
				video.save
			end

			user = User.find meeting.participant
			NotificationMailer.with(contact: user.email).notification_email.deliver_later
			puts "================================================================="
			puts ">>>>>> Notification email has been sent to #{user.name}."
			puts "================================================================="

		else
			puts "Somthing went wrong!"
		end

	end


	def edit_meeting
		prompt = "TYPE A MEETING ID FOR EDIT:"
		meeting_id = get_valid_meeting(prompt)
		meeting = Meeting.find meeting_id
		puts " "

		puts "PLEASE PROVIDE YOUR INPUTS TO UPDATE THE MEETING (#{meeting.title} dated #{meeting.meeting_date}):"
		puts " "
		
		
	  	title = get_valid_meeting_title
	  	meeting.title = title if !title.empty?

	  	type = get_valid_meeting_type
	  	meeting.meeting_type = type if !type.empty?

	  	date = get_valid_date
	  	meeting.meeting_date = date if !date.empty?

		time = get_valid_time
		meeting.meeting_time = time if !time.empty?

		print "Do you want to send notifications to participants(y/n):"
		send_notification = gets.chomp

		if(meeting.save)

			puts "Meeting updated successfully."
			if(send_notification.downcase =='n')
				puts "Skipping email notification to participants."
			else
				user = User.find meeting.participant
				NotificationMailer.with(contact: user.email).notification_email.deliver_later
				puts "================================================================="
				puts ">>>>>>>>> Notification email has been sent to #{user.name}."
				puts "================================================================="
			end	
		else
			puts "Somthing went wrong!"
		end
	end

	def view_meeting_for_participant
		puts "View Meeting for a participants"
	  	#tp User.all
		prompt = "Participant (please type user id to view the meeting invited for the user) :"
		participant = get_valid_user(prompt)
		tp Meeting.where(participant:participant)
	end

	def cancel_meeting
		prompt = "TYPE A MEETING ID FOR CANCEL:"
		meeting_id = get_valid_meeting(prompt)
		meeting = Meeting.find meeting_id
		meeting.status = "CANCELD"

		if(meeting.save)
			puts "Meeting has been canceled."
		else
			puts "Somthing went wrong!"
		end
	end

	def delete_meeting
		prompt = "TYPE A MEETING ID FOR DELETE:"
		meeting_id = get_valid_meeting(prompt)
		meeting = Meeting.find meeting_id
	  	if meeting.destroy
			puts "Meeting has been deleted."
		else
			puts "Somthing went wrong!"
		end
	end

	def view_meeting
		sql = "SELECT meetings.id, meetings.title, meetings.meeting_type, meetings.meeting_date, meetings.meeting_time, (select name from users where id=meetings.creator) as 'Meeting Creator', 
		(select name from users where id=meetings.participant) as 'Meeting Participant', video_meetings.link_url  FROM meetings LEFT JOIN video_meetings ON video_meetings.meeting_id = meetings.id LEFT JOIN users ON users.id = meetings.creator"

		tp ActiveRecord::Base.connection.execute(sql)
	end

	def menu_options

		options = """ 
		1. NEW MEETING
		2. EDIT MEETING
		3. VIEW MEETING
		4. VIEW MEETING FOR A PARTICIPANTS
		5. CANCEL MEETING
		6. DELETE MEETING
		"""

		puts "***********************************************************************************"
		puts "PLEASE CHOOSE YOUR OPTION (e.g. type 1 for new meeting)"
		puts options
		puts "***********************************************************************************"

		print "PLEASE SELECT AN OPTION:"

	end


	def main_menu

		ActiveRecord::Base.logger = nil
	
		menu_options		
		
		loop do

			option = gets.chomp

			break if(option=="\e")

			case option
				
				when '1'# New Meeting
				  choose_user
				  new_meeting 	

				when '2'# Edit Meeting

					if(Meeting.all.empty?)
						puts "NO MEETING FOUND, PLEASE CREATE MEETING FIRST"
					else	  
				  		edit_meeting
					end

				when '3'# View Meeting
				  	#tp Meeting.all
				  	view_meeting
				  	
			
				when '4'# view meeting for a participant
					view_meeting_for_participant

				when '5'# cancel meeting
				  	cancel_meeting

				when '6'#delete meeting
				  	delete_meeting

				 when '9' # main menu
				  	menu_options
				else# Invalid press
				  		
			end	 

			print "Press 9 for main menu || ESC for exit:  " if(option!='9')

		end#loop
	end

end

meeting_scheduler_cli = MeetingSchedulerCLI.new
meeting_scheduler_cli.main_menu