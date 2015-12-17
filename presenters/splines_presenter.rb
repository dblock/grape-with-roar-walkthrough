module SplinesPresenter
  include Roar::JSON::HAL
  include Roar::Hypermedia
  include Grape::Roar::Representer

  collection :to_a, extend: SplinePresenter, as: :splines, embedded: true
end
