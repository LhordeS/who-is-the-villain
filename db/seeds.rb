# db/seeds.rb
require 'open-uri'
require 'nokogiri'

user = User.find_or_create_by!(email: "test@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
end

Deed.create!([
  {
    user: user,
    title: "I skipped my friend's wedding for a work trip",
    public: true,
    ai_verdict: "at_fault",
    content: "My best friend's wedding was scheduled for the same weekend as a major client conference I was assigned to attend. I told my friend two weeks before the wedding that I couldn't make it. My manager said attendance wasn't strictly mandatory, but I felt skipping would hurt my chances at a promotion I've been working toward for two years. My friend hasn't spoken to me since."
  },
  {
    user: user,
    title: "I told my sister her boyfriend is bad for her",
    public: true,
    ai_verdict: "not_at_fault",
    content: "My sister has been dating someone for six months who I've seen speak down to her in front of family multiple times. Last Christmas dinner he interrupted her three times and laughed when she got a fact wrong. I pulled her aside and told her directly that I thought she deserved better and that his behavior worried me. She got angry and said I was being controlling and jealous of her relationship."
  },
  {
    user: user,
    title: "I returned a gift I didn't like without telling the person",
    public: false,
    ai_verdict: "contested",
    content: "My partner's mother spent a lot of effort picking out a decorative item for our apartment as a housewarming gift. I genuinely didn't like it and it didn't fit the aesthetic we'd been building. I returned it to the store without telling either my partner or their mother, used the store credit to buy something I actually wanted, and put that in the same spot. My partner found out three months later when their mother asked about it."
  },
  {
    user: user,
    title: "I didn't tell my coworker they had food in their teeth before a presentation",
    public: true,
    ai_verdict: "at_fault",
    content: "A colleague I'm not close with was about to present to senior leadership. I noticed they had something in their teeth while we were waiting in the hallway. I didn't say anything because I wasn't sure how to bring it up without embarrassing them and we were about to walk in. The presentation happened, and they found out afterward. They were visibly mortified."
  }
])

puts "Making 10 users..."
10.times do
  user = User.create!(
    email: Faker::Internet.email,
    password: 123123,
    username: Faker::Internet.username,
)
  gender = 'all'
  age = 'all'
  ethnicity = 'all'

  url = "https://this-person-does-not-exist.com/new?gender=#{gender}&age=#{age}&etnic=#{ethnicity}"
  json = URI.open(url).string
  src = JSON.parse(json)['src']
  avatar_url = "https://this-person-does-not-exist.com#{src}"
  file = URI.open(avatar_url)
  user.avatar.attach(io: file, filename: 'user.png', content_type: 'image/png')

end

puts "done!"
