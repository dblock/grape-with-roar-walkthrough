module SplinePresenter
  include Roar::Representer::JSON::HAL
  include Roar::Representer::Feature::Hypermedia
  include Grape::Roar::Representer

  property :uuid
  property :reticulated

  link :self do
    "http://localhost:9292/splines/#{uuid}"
  end
end
