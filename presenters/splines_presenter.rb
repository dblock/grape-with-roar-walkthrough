module SplinesPresenter
  include Grape::Roar::Representer
  include Roar::Representer::JSON::HAL
  include Roar::Representer::Feature::Hypermedia

  collection :to_a, extend: SplinePresenter, as: :splines, embedded: true
end
