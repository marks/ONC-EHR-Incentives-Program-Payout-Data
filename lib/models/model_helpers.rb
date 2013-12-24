module ModelHelpers
  def incentives_received
    incentives = {}
    (2011..2013).each do |year|
      incentives["year_#{year}"] = (self["PROGRAM YEAR #{year}"].to_s.upcase == "TRUE")
      incentives["year_#{year}_amt"] = (self["PROGRAM YEAR #{year} CALC PAYMENT"].nil? ? 0 : self["PROGRAM YEAR #{year} CALC PAYMENT"])
    end
    return incentives
  end

  def npi
    self["PROVIDER NPI"].present? ? self["PROVIDER NPI"] : nil
  end

  def phone_number
    if self["general"] && self["general"]["phone_number"].present?
      self["general"]["phone_number"]
    elsif self["PROVIDER PHONE NUM"].present?
      self["PROVIDER PHONE NUM"]
    else
      nil
    end
  end

  def to_s
    name
  end

  def name
    if self["general"].present? && self["general"]["hospital_name"].present? 
      self["general"]["hospital_name"]
    elsif self["PROVIDER - ORG NAME"].present?
      self["PROVIDER - ORG NAME"]
    elsif self["PROVIDER NAME"].present?
      self["PROVIDER NAME"]
    else
      nil
    end
  end

  def address
    if self["PROVIDER  ADDRESS"].present?
      {:address => self["PROVIDER  ADDRESS"], :city => self["PROVIDER CITY"], :state => self["PROVIDER STATE"], :zip => self["PROVIDER ZIP 5 CD"]} 
    elsif self["general"]["address_1"].present?
      {:address => self["general"]["address_1"], :city => self["general"]["city"], :state => self["general"]["state"], :zip => self["general"]["zip_code"]} 
    else
      {}
    end
  end

  def full_address
    "#{address[:address]}, #{address[:city]}, #{address[:state]} #{address[:zip]}"
  end
end
