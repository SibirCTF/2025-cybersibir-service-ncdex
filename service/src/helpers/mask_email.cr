module MaskEmail
  def self.mask_domain(email : String) : String
    parts = email.split("@")
    return email if parts.size != 2

    local, domain = parts
    return email if domain.size < 4

    masked_domain = domain[0..2] + ("*" * (domain.size - 3))
    "#{local}@#{masked_domain}"
  end
end
