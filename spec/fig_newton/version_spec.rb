require 'spec_helper'

RSpec.describe FigNewton do
  it 'has a version number' do
    expect(FigNewton::VERSION).not_to be nil
  end

  it 'follows semantic versioning' do
    expect(FigNewton::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
