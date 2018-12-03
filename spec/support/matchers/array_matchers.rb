# frozen_string_literal: true

RSpec::Matchers.define :contain_in_order do |expected_subset|
  match do |given_superset|
    (given_superset & expected_subset) == expected_subset
  end
end
