require 'watir'
require 'colorize'

print "Enter Username:".black.on_white + " "
username = gets.chomp
print "Enter Password: ".black.on_white + " "
password = gets.chomp

unfollow_counter = 0
following_counter = 0

start_time = Time.now

# Open Browser, Navigate to Login page
b = Watir::Browser.new :chrome, headless: true
b.goto "instagram.com/accounts/login/"

# Inject username and password into text fields
puts "Logging in...".green
b.text_fields[0].set username
b.text_fields[1].set password

# Click log in button
b.button(class: '_njrw0').click
sleep(2)
puts "We're in #hackerman".green

# Navigate to user page and open "following" modal
b.goto "instagram.com/#{username}"
sleep(1)
following_counter = b.element(class: '_t98z6', index: 2).text.gsub(',', '').to_i
puts "Following: #{following_counter}".yellow
b.element(class: '_t98z6', index: 2).click
sleep(2)

flag = true
while true do
  while flag do

    # Scroll down to load more followers
    15.times do
      b.driver.execute_script('document.getElementsByClassName("_gs38e")[0].scrollBy(0, 1059);')
      sleep(1)
    end

    # Loop through each follow/unfollow button
    b.lis(class: '_6e4x5').each do |li|
      follow_button = li.div(class: '_npuc5').div(class: '_mtnzs').span(class: '_ov9ai').child
      # Ensure you are following them before unfollowing. Otherwise text would read "Follow"
      follow_button.click if follow_button.text == "Following"

      puts "Unfollowed: #{li.div(class: '_npuc5').div(class: '_f5wpw').div(class: '_eryrc').div(class: '_2nunc').a.text}"

      # Update counters
      unfollow_counter += 1
      following_counter -= 1

      # Every 180 unfollows break out of this and parent loop
      if unfollow_counter % 180 == 0
        flag = false
        break
      end

      # End program if no one else left to unfollow
      if following_counter == 0
        abort("Everyone has been unfollowed. Program complete.")
      end
      sleep(2)
    end
  end

  puts "Unfolowed a total of #{unfollow_counter} and have #{following_counter} remaining. Sleeping for 70mins".yellow
  sleep(60 * 70)
  flag = true
end
