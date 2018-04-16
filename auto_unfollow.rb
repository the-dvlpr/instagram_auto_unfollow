require 'watir'
require 'colorize'
require 'io/console'

print "Enter Username:".black.on_white + " "
username = gets.chomp
print "Enter Password: ".black.on_white + " "
password = STDIN.noecho(&:gets).chomp
puts ""


unfollow_counter = 0
starting_following_counter = 0
current_following_counter = 0
unfollows_per_hour = 100
# Array of username strings you don't want to unfollow
whitelist = []

# Open Browser, Navigate to Login page
b = Watir::Browser.new :chrome, headless: true
b.goto "instagram.com/accounts/login/"

# Inject username and password into text fields
puts "Logging in...".green
begin
  b.text_fields[0].set username
  b.text_fields[1].set password

  # Click log in button
  b.button(class: '_njrw0').click
rescue
  puts "Unable to log you in. Check your password and ensure you have two-step authentication off in your instagram settings.".red
  abort
end
sleep(2)
puts "Okay, we're in.".green


flag = true
while true do

  # Navigate to user page and open "following" modal
  b.goto "instagram.com/#{username}"
  sleep(2)

  current_following_counter = b.element(class: '_t98z6', index: 2).text.gsub(',', '').to_i

  puts "Currently following: " + "#{current_following_counter}".cyan
  if starting_following_counter == 0
    starting_following_counter = current_following_counter
    puts "Unfollowing " + "#{unfollows_per_hour}".cyan + " accounts per hour, which is " + "1".cyan + " unfollow every " + "#{60 * 60 / unfollows_per_hour}".cyan + " seconds"
  end

  b.element(class: '_t98z6', index: 2).click
  sleep(2)

  while flag do

    # Scroll down to load more followers
    b.driver.execute_script('document.getElementsByClassName("_gs38e")[0].scrollBy(0, 1059);')
    sleep(1)

    # Loop through each follow/unfollow button
    b.lis(class: '_6e4x5').each do |li|
      follow_button = li.div(class: '_npuc5').div(class: '_mtnzs').span(class: '_ov9ai').child
      # Ensure you are following them before unfollowing. Otherwise text would read "Follow"
      if (whitelist.length == 0) || (!whitelist.include? li.div(class: '_npuc5').div(class: '_f5wpw').div(class: '_eryrc').div(class: '_2nunc').a.text)
        follow_button.click if follow_button.text == "Following"

        # Update counters
        unfollow_counter += 1
        current_following_counter -= 1

        puts "Unfollow ##{unfollow_counter}: #{li.div(class: '_npuc5').div(class: '_f5wpw').div(class: '_eryrc').div(class: '_2nunc').a.text}"

        # Every 180 unfollows break out of this and parent loop
        if unfollow_counter % 15 == 0
          flag = false
          break
        end

        # End program if no one else left to unfollow
        if current_following_counter == 0
          abort("Everyone has been unfollowed. Program complete.")
        end
      else
        puts "Skipped, whitelisted: #{li.div(class: '_npuc5').div(class: '_f5wpw').div(class: '_eryrc').div(class: '_2nunc').a.text}".light_black
      end

       # Seconds in an hour / number of unfollows.
       # If 150, 1 unfollow every 24 seconds. Don't exceed 150 (IG's rate limit)
      sleep(60 * 60 / unfollows_per_hour)
    end
  end
  puts "-".yellow * 30
  puts "Succesfully unfolowed a total of " + "#{starting_following_counter - current_following_counter}".cyan + " and have " + "#{b.element(class: '_t98z6', index: 2).text.gsub(',', '').to_i}".cyan + " remaining."
  puts "-".yellow * 30
  flag = true
end
