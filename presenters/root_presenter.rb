module RootPresenter
  include Roar::JSON::HAL
  include Roar::Hypermedia
  include Grape::Roar::Representer

  link :self do
    "http://localhost:9292"
  end

  link :splines do
    "http://localhost:9292/splines"
  end

  link :spline do |opts|
    {
      href: "http://localhost:9292/splines/{uuid}",
      templated: true
    }
  end
end
