require 'rails_helper'

RSpec.describe do
  describe do
    it '1. `profile_image`カラムに対して画像を登録されるようにフォームが生成されていること' do
      visit new_user_path
      expect(find('input[name="user[profile_image]"]')).to be_visible
    end
  end
  describe do
    before do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user[profile_image]', "#{Rails.root}/spec/fixtures/images/スクリーンショット 2021-01-08 18.33.25のコピー.png"
      find('input[type="submit"]').click
    end
    it '2. アカウント登録時にプロフィール画像を登録できること' do
      expect(page).to have_content 'アカウントを登録しました。'
    end
    it '3. Active Strageが使用されていること' do
      expect(User.last.profile_image.class).to eq ActiveStorage::Attached::One
    end
    it '4. プロフィール画像を選択してユーザ登録した際、詳細画面に遷移させ、プロフィール画像を表示されること' do
      expect(current_path).to eq user_path(User.last.id)
      # 画像の全体パスだと投稿時刻によって変化するため、変化しない一部比較しテスト
      expect(page.find('img')['src']).to have_content '202021-01-08%2018.33.25%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.png'
    end
  end
  describe do
    it '5. プロフィール画像を選択せずにユーザ登録した際、エラーを発生させずに詳細画面に遷移させること' do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      find('input[type="submit"]').click
      expect(current_path).to eq user_path(User.last.id)
    end
  end
  describe do
    it '6. アカウント登録した際、Action Mailerを使ってそのユーザにメールを送信すること' do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user[profile_image]', "#{Rails.root}/spec/fixtures/images/スクリーンショット 2021-01-08 18.33.25のコピー.png"
      perform_enqueued_jobs do
        find('input[type="submit"]').click
      end
      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq ['user@gmail.com']
    end
  end
  describe do
    it "7. 要件で指定したメール文章が送信されていること" do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user[profile_image]', "#{Rails.root}/spec/fixtures/images/スクリーンショット 2021-01-08 18.33.25のコピー.png"
      perform_enqueued_jobs do
        find('input[type="submit"]').click
      end
      email = ActionMailer::Base.deliveries.last
      expect(email.from).to eq ["admin@example.com"]
      expect(email.subject).to eq "登録完了"
    end
  end
  describe do
    it '8. Acitve Jobを実装し、`deliever_later`メソッドを使って非同期でメールを送信すること' do
      visit new_user_path
      fill_in 'user_name', with: 'sample'
      fill_in 'user_email', with: 'user@gmail.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      attach_file 'user[profile_image]', "#{Rails.root}/spec/fixtures/images/スクリーンショット 2021-01-08 18.33.25のコピー.png"
      expect { find('input[type="submit"]').click }.to change { enqueued_jobs.size }.by(2)
    end
  end
end
