require 'rails_helper'

RSpec.describe "UserRegistration", type: :system do
  include ActiveJob::TestHelper

  before do
    driven_by(:rack_test)
  end

  it "registers a new user with profile image and sends email" do
    visit new_user_path

    fill_in "Name", with: "Test User"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    
    # Create a dummy image file
    image_path = Rails.root.join('spec', 'fixtures', 'test_image.png')
    File.open(image_path, 'wb') do |f|
      f.write(Base64.decode64('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'))
    end

    attach_file "Profile image", image_path

    expect {
      perform_enqueued_jobs do
        click_button "Create my account"
      end
    }.to change { User.count }.by(1)
     .and change { ActionMailer::Base.deliveries.count }.by(1)

    user = User.last
    expect(page).to have_content("Test User")
    expect(page).to have_content("Email: test@example.com")
    expect(page).to have_selector("img")
    expect(user.profile_image).to be_attached

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq(["test@example.com"])
    expect(mail.subject).to eq("登録が完了しました")
    expect(mail.body.encoded).to include("ユーザー登録が完了しました。")
    
    # Cleanup
    File.delete(image_path) if File.exist?(image_path)
  end

  it "registers a new user without profile image" do
    visit new_user_path

    fill_in "Name", with: "Test User 2"
    fill_in "Email", with: "test2@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"

    expect {
      perform_enqueued_jobs do
        click_button "Create my account"
      end
    }.to change { User.count }.by(1)

    expect(page).to have_content("Test User 2")
    expect(page).not_to have_selector("img")
  end
end
