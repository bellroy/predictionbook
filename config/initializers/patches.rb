# https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ
# 
# Upgrade to rails 3.1.[latest] at some point

ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)