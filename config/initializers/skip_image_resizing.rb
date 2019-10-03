if Rails.env.test?
	Carrierwave.configure do |config|
		config.enable_processing = false
	end	
end