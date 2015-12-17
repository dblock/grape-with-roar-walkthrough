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

Add to `api.rb`.

```ruby
  resource :splines do
    desc 'Return a spline.'
    get ':uuid' do
      Spline.new(uuid: params[:uuid])
    end
  end
```

You can navigate to http://localhost:9292/splines/1 and see this `spline.to_s`.

Make a presenter in `presenters/spline_presenter.rb`.

```ruby
module SplinePresenter
  include Roar::JSON::HAL
  include Roar::Hypermedia
  include Grape::Roar::Representer

  property :uuid
  property :reticulated

  link :self do
    "http://localhost:9292/splines/#{uuid}"
  end
end
```

Require JSON+HAL in `config.ru`.

```ruby
require 'roar/representer'
require 'roar/json'
require 'roar/json/hal'

require 'presenters/spline_presenter'
```

Present the spline in `api.rb`.

```ruby
desc 'Return a spline.'
get ':uuid' do
  present Spline.new(uuid: params[:uuid]), with: SplinePresenter
end
```

See it at http://localhost:9292/splines/123.

#### Return a Collection of Splines

Create a `presenters/splines_presenter.rb`.

``` ruby
module SplinesPresenter
  include Roar::JSON::HAL
  include Roar::Hypermedia
  include Grape::Roar::Representer

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

client.splines.to_a.each do |spline|
    puts "Spline #{spline.uuid} is #{spline.reticulated ? 'reticulated' : 'not reticulated'}."
end
```

### LICENSE

[MIT License](LICENSE)
