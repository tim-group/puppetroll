metadata :name        => "Puppet Rollout",
         :description => "Rolls out puppet in a defined order and fails the build if anything is incorrect",
         :author      => "Infrastructure Team",
         :license     => "MIT",
         :version     => "1.0",
         :url         => "http://www.timgroup.com",
         :timeout     => 120

action "run", :description => "Runs Puppet" do
  display :always
end
