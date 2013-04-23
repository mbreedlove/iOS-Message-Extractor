#!/usr/bin/env ruby

require 'sqlite3'

db = SQLite3::Database.new('sms.db')
db.execute("SELECT address, text, date, flags, is_madrid, madrid_handle, madrid_flags FROM message ORDER BY date") do |row|
  address = row[0]
  text = row[1]
  date = row[2]
  flags = row[3]
  is_madrid = row[4]
  madrid_handle = row[5]
  madrid_flags = row[6]

  next if text.nil? # No need parsing blank messages

  output = ""

  if is_madrid == 1 # Check if iMessage
    if madrid_flags == 12289 or madrid_flags == 77825 # Recieved
      output += "Rcvd: #{madrid_handle}"
    elsif madrid_flags == 36869 or madrid_flags == 45061 or madrid_flags == 32773 or madrid_flags == 102405 # Sent
      output += "Sent: #{madrid_handle}"
    end

  else # Regular text message
    if flags == 2 # Recieved
      output += "Rcvd: #{address}"
    elsif flags == 3 # Sent
      output += "Sent: #{address}"
    elsif flags == 35 # Send error
      output += "Sent: #{address} **Failed to send**"
    else
      output += "Unkn: #{address} (Flag: #{flags})"
    end
  end

  output += "\n"
  output += Time.at(date).strftime('%b %d, %Y at %I:%M %P') + "\n"
  output += text + "\n"
  output += "\n"

  puts output
end
