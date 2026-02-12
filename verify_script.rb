# verify_script.rb
begin
  puts "Starting verification..."
  
  # Clean up previous test user
  User.find_by(email: 'verify@example.com')&.destroy

  # Create user with profile image
  user = User.new(
    name: 'Verify User',
    email: 'verify@example.com',
    password: 'password',
    password_confirmation: 'password'
  )

  # Attach image
  image_path = Rails.root.join('spec', 'fixtures', 'test_image.png')
  unless File.exist?(image_path)
    # Create dummy image if needed
    File.open(image_path, 'wb') do |f|
      f.write(Base64.decode64('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'))
    end
  end
  
  user.profile_image.attach(io: File.open(image_path), filename: 'test_image.png', content_type: 'image/png')
  
  if user.save
    puts "User created successfully."
    puts "Profile Image Attached: #{user.profile_image.attached?}"
    
    # Check for email
    # Perform enqueued jobs
    # This might require ActiveJob test helper or just checking if job was enqueued
    # But in development mode with async adapter, it might just queue it.
    # We can check ActionMailer::Base.deliveries if checking sync, but usually deliver_later is async.
    # However, if we set queue_adapter to :inline for this script, we can check.
  else
    puts "User creation failed: #{user.errors.full_messages}"
    exit 1
  end

  # Check email
  puts "Enqueued Jobs: #{ActiveJob::Base.queue_adapter.enqueued_jobs.size}" if ActiveJob::Base.queue_adapter.respond_to?(:enqueued_jobs)

rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
  exit 1
end
