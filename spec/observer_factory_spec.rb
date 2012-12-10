require 'spec_helper'

describe FayeRails::Controller::ObserverFactory do
  context "create new observer" do
    before(:all) do
      ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
      ActiveRecord::Migration.create_table :ryans do |t|
        t.string :name
        t.timestamps
      end

      Ryan = Class.new(ActiveRecord::Base)
      FayeRails::Controller::ObserverFactory.define(Ryan, :before_create) { |r| r.name = "will create" }
      FayeRails::Controller::ObserverFactory.define(Ryan, :after_create) { |r| }
      FayeRails::Controller::ObserverFactory.define(Ryan, :before_update) { |r| r.name = "will update" }
    end

    it { FayeRails::Controller::ObserverFactory.observer("RyanCallbacks").should_not be_nil }
    it { FayeRails::Controller::ObserverFactory.observer("RyansCallbacks").should be_nil }

    context "should define a module with callback methods" do
      it { RyanCallbacks.should be_a_kind_of Module }
      it { RyanCallbacks.method_defined?(:after_create).should be_true }
      it { RyanCallbacks.method_defined?(:before_create).should be_true }
      it { RyanCallbacks.method_defined?(:before_update).should be_true }
      it { RyanCallbacks.method_defined?(:before_validation).should be_false }
      it { RyanCallbacks.method_defined?(:after_validation).should be_false }
      it { RyanCallbacks.method_defined?(:before_save).should be_false }
      it { RyanCallbacks.method_defined?(:after_save).should be_false }
      it { RyanCallbacks.method_defined?(:after_commit).should be_false }
    end

    context "callbacks should be called" do
      it "should call after_create callback" do
        r = Ryan.create!(:name => 'ryan')
        r._create_callbacks.length.should == 2
        r.name.should == "will create"

        r.name = "hey"
        r.save
        r.name.should == "will update"
      end
    end

  end
end
