A live coding exercise for creating a Hypermedia API w/ Grape and Roar for [this talk](http://www.meetup.com/API-Craft-NYC/events/209294892).

#### Create Gemfile

```ruby
source 'http://rubygems.org'

gem 'grape'
gem 'grape-roar'
```

Run `bundle install`.

#### Create an API Root

Create `api.rb`.

```ruby
class Api < Grape::API
  format :json

  desc 'Root of the Hypermedia API.'
  get do
    { foo: 'bar' }
  end
end
```

Create `config.ru`.

```ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'

Bundler.require :default

require 'api'

run Api
```

Run `rackup`, browse to http://localhost:9292, see the API.

#### Create a Model

Add `activemodel` to Gemfile.

```ruby
gem 'activemodel', require: 'active_model'
```

Create `models/spline.rb`.

```ruby
class Spline
  include ActiveModel::Model

  attr_accessor :uuid
  attr_accessor :reticulated

  def initialize(attrs = { reticulated: [true, false].sample })
    super(attrs)
    @uuid ||= SecureRandom.uuid
    @reticulated = !!attrs[:reticulated]
  end
end
```

#### Return a Spline in the API

```ruby
  resource :splines do
    desc 'Return a spline.'
    get ':uuid' do
      Spline.new(uuid: params[:uuid])
    end
  end
```

Make a presenter.

```ruby
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
```

Require JSON+HAL.

```ruby
require 'roar/representer'
require 'roar/representer/json'
require 'roar/representer/json/hal'

require 'presenters/spline_presenter'
```

Present the spline.

```ruby
present Spine.new(uuid: params[:uuid]), with: SplinePresenter
```

See it at http://localhost:9292/splines/123.

#### Return a Collection of Splines

Create a `presenters/splines_presenter.rb`.

``` ruby
module SplinesPresenter
  include Grape::Roar::Representer
  include Roar::Representer::JSON::HAL
  include Roar::Representer::Feature::Hypermedia

  collection :to_a, extend: SplinePresenter, as: :splines, embedded: true
end
```

Require it.

```ruby
require 'presenters/splines_presenter'
```

Present splines.

```ruby
desc 'Return a few splines.'
get do
  present 5.times.map { Spline.new }, with: SplinesPresenter
end
```

#### Add a Root Presenter

Create `presenters/root_presenter.rb`.

```ruby
module RootPresenter
  include Roar::Representer::JSON::HAL
  include Roar::Representer::Feature::Hypermedia
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
```

Require it.

```ruby
require 'presenters/root_presenter'
```

Present it.

```ruby
desc 'Root of the Hypermedia API.'
get do
  present self, with: RootPresenter
end
```

#### Try It

``` ruby
require 'hyperclient'

client = Hyperclient.new('http://localhost:9292')

client.splines.count

client.splines.each do |spline|
    puts "Spline #{spline.uuid} is #{spline.reticulated ? 'reticulated' : 'not reticulated'}."
end
```

### LICENSE

[MIT License](LICENSE)
