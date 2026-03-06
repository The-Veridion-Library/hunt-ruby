class BadgeAwarder
  BADGES = [
    { name: 'First Find',  type: 'finds',  threshold: 1   },
    { name: 'Book Worm',   type: 'finds',  threshold: 10  },
    { name: 'Librarian',   type: 'hidden', threshold: 5   },
    { name: 'Centurion',   type: 'points', threshold: 100 },
  ].freeze

  def self.call(user)
    BADGES.each do |b|
      badge = Badge.find_by(name: b[:name])
      next unless badge
      next if UserBadge.exists?(user: user, badge: badge)

      count = case b[:type]
              when 'finds'  then user.finds.count
              when 'hidden' then user.books.count
              when 'points' then user.points.to_i
              end

      if count >= b[:threshold]
        UserBadge.create!(user: user, badge: badge, awarded_at: Time.current)
      end
    end
  end
end