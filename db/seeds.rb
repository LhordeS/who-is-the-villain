# db/seeds.rb
require 'open-uri'
require 'nokogiri'

Deed.destroy_all
User.destroy_all

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


DEED_TITLES = [
  "I told my sister her baby is ugly",
  "I ate my roommate's last bit of food during a snowstorm",
  "I refused to give up my seat for a pregnant woman",
  "I told my boss exactly what I think of him at the Christmas party",
  "I let my neighbour's dog out of their garden on purpose",
  "I reported my coworker for taking long lunches",
  "I didn't tell my friend her boyfriend was cheating",
  "I laughed at my dad when he fell over",
  "I skipped my best friend's wedding for a concert",
  "I told a child that Santa isn't real",
  "I used my girlfriend's savings without asking",
  "I got my brother fired from his job",
  "I blocked my mum on everything after an argument",
  "I let my flatmate take the blame for something I did",
  "I ghosted someone after three years of dating",
  "I told my aunt her cooking is inedible",
  "I sold my neighbour's bike that was left in my garden",
  "I didn't invite my dad to my graduation",
  "I gave my friend's secret away to the whole group",
  "I faked being sick to get out of a funeral",
  "I took credit for my colleague's work in a big meeting",
].freeze

DEED_BODIES = [
  "I know it sounds bad but honestly in the moment I just didn't think. Would I do it again? Probably not. Do I regret it? A little.",
  "Everyone in my life is telling me I went too far but I genuinely don't see what the big deal is. Am I missing something?",
  "I've been sitting with this for weeks and I still don't know if I did the right thing. Part of me thinks I was justified.",
  "Look, I'm not proud of it. But the situation pushed me to it and I'm not sure anyone else would have acted differently.",
  "My friends are split down the middle on this one. Half say I'm totally in the wrong, the other half have my back.",
  "I did what I did and I'd probably do it again honestly. Life is short and I'm done people pleasing.",
  "The worst part is I don't even feel that guilty. Is that bad? I feel like that might be bad.",
  "I tried to justify it to myself for a while but deep down I think I knew it wasn't right. Still did it though.",
  "Nobody got seriously hurt so I'm struggling to understand why everyone is so upset with me about this.",
  "I've apologised once and I'm not doing it again. If that makes me the villain then so be it.",
  "At the time it felt totally reasonable. Looking back now I can see how it might have come across differently.",
  "I've never done anything like this before and I genuinely don't know what came over me.",
  "The other person involved hasn't spoken to me since and I'm starting to think this might be more serious than I thought.",
  "My partner thinks I should apologise. I think they should mind their own business. We're at a stalemate.",
  "I'm not asking if it was nice. I'm asking if it was wrong. There's a difference and people keep confusing them.",
  "Honestly I'd been holding this in for years and it just came out. I regret the timing more than anything.",
  "The reaction I got was so over the top that I almost laughed. People need to get a grip.",
  "I know exactly how this looks from the outside. I just want someone to hear my side of it.",
  "Would a good person have done this? Probably not. But I was tired and fed up and something snapped.",
  "I'm not a bad person. I just had a bad moment. Those are different things, right?",
].freeze

users = User.all
10.times do
  Deed.create!(
    title: DEED_TITLES.sample,
    content:  DEED_BODIES.sample,
    user:  users.sample,
    public: true,
  )
end

puts "Distributing votes"
Deed.all.each do |deed|
  users.sample(rand(1..100)).each do |user|
    next if user == deed.user
    roll = rand(100)
    if roll < 75
      deed.upvote_by user
    elsif roll < 88
      deed.downvote_from user
    else
      deed.liked_by user, vote_scope: "flag"
    end
  end
end

puts "done!"
