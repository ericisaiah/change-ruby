# A Change.org API Ruby Library Gem

This has not yet been released. Stay tuned.

## Description
A Ruby library for the Change.org API. This is a personal project and not an official library from Change.org.

## Installation

The HTTParty gem is required.

    gem install httparty

Then install `change-ruby`:

    gem install change-ruby

## API Key

Obtain a Change.org API key and secret token at [change.org/developers](http://www.change.org/developers).

## API Documentation

The full Change.org documentation can be found [on Github here](https://github.com/change/api_docs).

## Features

This gem allows you to interact with all* resources currently available by
Change.org's API:

- Petitions
  * Signatures
  * Targets of the petition ("targets")
  * Reasons for signing ("reasons")
  * News updates ("updates")
- Users
- Organizations
  * Petitions created

\* See _TODO_ list at the bottom of this page for resources coming soon.

## Usage

### Setup

First, require the library:

    require 'change-ruby'

Then set up a Client object to talk to Change.org. You'll need your Change.org
API key. If you intend to make requests to modify an existing resource (e.g. add
signatures to a petition), you'll also need to supply your secret token. If you
only intend to retrieve information, you can leave it off.

    client = Change::Requests::Client.new({ :api_key => 'my_api_key', :secret_token => 'my_secret_token' })

For convenience, include the resources module:

    include Change::Resources

### Get a resource

To retrieve an existing resource on Change.org and use it in your code, you need
to create a shell object and then load it with its information.

For example, to get a petition, first declare it locally and specify the client
it will use to make requests:

    petition = Petition.new(client)

Then, load the petition from its unique Change.org ID:

    petition.load(132448)

If you don't know the petition's ID, you can use the `get_id` method with the
petition's URL:

    petition.get_id("http://www.change.org/petitions/dunkin-donuts-stop-using-styrofoam-cups-and-switch-to-a-more-eco-friendly-solution")

You can also skip that step and just load the petition by the URL:

    petition.load("http://www.change.org/petitions/dunkin-donuts-stop-using-styrofoam-cups-and-switch-to-a-more-eco-friendly-solution")

Once you load the petition, you can access its properties by its properties
attribute:

    petition.properties['signature_count']

### Get resource collections

To retrieve a child resource collection of a particular parent resource, you can
use the `load` method on its collection name. For example:

    petition.targets.load

Depending on the resource collection (specified by the documentation), you can
also use paging and field modifiers on your requests:

    petition.signatures.load({ :page_size => 2, :sort => 'time_desc' })

### Get a resource authorization key

If you want to modify a resource, such as adding signatures to a petition,
you'll need an authorization key. For petitions, you can obtain one on the
petition page and then use it in your code. Or you can do it programmatically:

    petition.request_auth_key({
      :requester_email => "example@test.com",
      :source => "http://www.mywebsite.com",
      :source_description => "I'll be gathering signatures to help the petition."
    })

Change.org will respond with an authorization key that will be automatically
added to the authorization keys on `petition`. Although you'll rarely need to
access it directly, you can see your auth key by calling it, or if you have
multiple, by specifying which one you want to see:

    petition.auth_key
    petition.auth_key(1)

### Adding a signature to a petition

Once you have an authorization key for a petition, and your `Client` object has
a secret token specified, you can add signatures to a petition:

    petition.add_signature({
      :email => 'barkley@exampledogs.com',
      :first_name => 'Barkley',
      :last_name => 'Dog',
      :address => '123 Sesame St NW'
      :city => 'Washington',
      :state_province => 'DC',
      :postal_code => '20011',
      :country_code => 'US'
    })

That's it! Doing this will use the first auth key by default, and give this
signature the source specified in that auth key. But you can also specify a
different one to use by adding it as an argument to `add_signature`.

    petition.add_signature(signature_hash, petition.auth_keys(3))

## TODO

- Add new resource collections:
  * Petitions signed by a user
  * Petitions created by a user
- Have returned properties on resources become attributes on the object, so we can make nice calls like, `petition.signature_count` instead of `petition.properties['signature_count']`
