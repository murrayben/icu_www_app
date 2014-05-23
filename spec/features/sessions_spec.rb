require 'spec_helper'

describe "Sessions" do
  before(:each) do
    visit "/sign_in"
  end

  let(:user)            { create(:user) }
  let(:password)        { "password" }
  let(:bad_password)    { "drowssap" }
  let(:ip)              { "127.0.0.1" }
  let(:admin_role)      { "admin" }
  let(:non_admin_roles) { User::ROLES.reject{ |role| role == "admin" }.sample(2).sort.join(" ") }
  let(:sign_in_button)  { I18n.t("session.sign_in") }
  let(:sign_in_title)   { I18n.t("session.sign_in") }
  let(:email_text)      { I18n.t("email") }
  let(:password_text)   { I18n.t("user.password") }
  let(:success)         { "div.alert-success" }
  let(:failure)         { "div.alert-danger" }

  it "arriving at the sign in page" do
    expect(page).to have_title(sign_in_title)
    expect(page).to have_xpath("//form//input[@name='email']")
    expect(page).to have_xpath("//form//input[@name='password']")
  end

  it "signing in and signing out" do
    fill_in email_text, with: user.email
    fill_in password_text, with: password
    click_button sign_in_button
    expect(page).to have_title(I18n.t("icu"))
    expect(page).to have_css(success, text: I18n.t("session.signed_in_as"))
    expect(Login.count).to eq 1
    expect(user.logins.where(user_id: user.id, ip: ip, roles: nil, error: nil).count).to eq(1)
    click_link "Sign out"
    expect(page).to have_title(sign_in_title)
    expect(page).to have_xpath("//form//input[@name='email']")
  end

  it "entering an invalid email" do
    bad_email = "bad." + user.email
    fill_in email_text, with: bad_email
    fill_in password_text, with: "password"
    click_button sign_in_button
    expect(page).to have_title(sign_in_title)
    expect(page).to have_css(failure, text: I18n.t("session.invalid_email"))
    expect(Login.count).to eq 0
  end

  it "entering an invalid password" do
    fill_in email_text, with: user.email
    fill_in password_text, with: bad_password
    click_button sign_in_button
    expect(page).to have_title(sign_in_title)
    expect(page).to have_css(failure, text: I18n.t("session.invalid_password"))
    expect(Login.count).to eq 1
    expect(user.logins.where(user_id: user.id, ip: ip, roles: nil, error: "invalid_password").count).to eq(1)
  end

  it "the user's subscription has expired" do
    user = create(:user, expires_on: 1.year.ago.at_end_of_year)
    fill_in email_text, with: user.email
    fill_in password_text, with: "password"
    click_button sign_in_button
    expect(page).to have_title(sign_in_title)
    expect(page).to have_selector(failure, text: I18n.t("session.subscription_expired"))
    expect(Login.count).to eq 1
    expect(user.logins.where(user_id: user.id, ip: ip, roles: nil, error: "subscription_expired").count).to eq(1)
  end

  it "recording the user's current role" do
    create(:user, roles: "admin") # so there is a last admin
    fill_in email_text, with: user.email
    fill_in password_text, with: password
    click_button sign_in_button
    visit "/sign_out"
    user.roles = admin_role
    user.save
    fill_in email_text, with: user.email
    fill_in password_text, with: password
    click_button sign_in_button
    visit "/sign_out"
    fill_in email_text, with: user.email
    fill_in password_text, with: password
    click_button sign_in_button
    visit "/sign_out"
    user.roles = non_admin_roles
    user.save
    fill_in email_text, with: user.email
    fill_in password_text, with: password
    click_button sign_in_button
    expect(Login.count).to eq(4)
    expect(user.logins.count).to eq(4)
    expect(user.logins.where(roles: nil, ip: ip).count).to eq(1)
    expect(user.logins.where(roles: admin_role, ip: ip).count).to eq(2)
    expect(user.logins.where(roles: non_admin_roles, ip: ip).count).to eq(1)
  end
end
