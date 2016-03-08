1. Takes a hash argument for `initialize`
2. Provides an `encrypt` method that returns the encrypted string
3. Provides a `decrypt` method that returns the plaintext

## Why?

The options available were either too complicated under the hood or had weird
edge cases that made the library hard to use. I wanted to write something
simple that *just works*.

## Usage

```ruby
class MyModel < ActiveRecord::Base
  crypt_keeper :field, :other_field, :encryptor => :aes_new, :key => 'super_good_password', salt: 'salt'
end

model = MyModel.new(field: 'sometext')
model.save! #=> Your data is now encrypted
model.field #=> 'sometext'
```

It works with all persistences methods: `update_attributes`, `create`, `save`
etc.

That means using `update_column` will not perform any encryption. This is
expected behavior, and has its use cases. An example would be migrating from
one type of encryption to another. Using `update_column` would allow you to
update the content without going through the current encryptor.

## Encodings

You can force an encoding on the plaintext before encryption and after decryption by using the `encoding` option. This is useful when dealing with multibyte strings:

```ruby
class MyModel < ActiveRecord::Base
  crypt_keeper :field, :other_field, :encryptor => :aes_new, :key => 'super_good_password', salt: 'salt', :encoding => 'UTF-8'
end

model = MyModel.new(field: 'Tromsø')
model.save! #=> Your data is now encrypted
model.field #=> 'Tromsø'
model.field.encoding #=> #<Encoding:UTF-8>
```

## Adding encryption to an existing table

If you are working with an existing table you would like to encrypt, you must use the `MyExistingModel.encrypt_table!` class method.

```ruby
class MyExistingModel < ActiveRecord::Base
  crypt_keeper :field, :other_field, :encryptor => :aes_new, :key => 'super_good_password', salt: 'salt'
end

MyExistingModel.encrypt_table!
```

Running `encrypt_table!` will encrypt all rows in the database using the encryption method specificed by the `crypt_keeper` line in your model.

## Searching
Searching ciphertext is a complex problem that varies depending on the encryption algorithm you choose. All of the bundled providers include search support, but they have some caveats.

* AES
  * The Ruby implementation of AES uses a random initialization vector. The same plaintext encrypted multiple times will have different output each time for the ciphertext. Since this is the case, it is not possible to search leveraging the database. Database rows will need to be filtered in memory. It is suggested that you use a scope or ActiveRecord batches to narrow the results before seaching them.

* Mysql AES
 * Surprisingly, MySQL's implementation of AES does not use a random initialization vector. The column containing the ciphertext can be indexed and searched quickly.

* PostgresSQL PGP
 * PGP also uses a random initialization vector which means it generates unique output each time you encrypt plaintext. Although the database can be searched by performing row level decryption and comparing the plaintext, it will not be able to use an index. A scope or batch is suggested when searching.

## How the search interface is used

```ruby
Model.search_by_plaintext(:field, 'searchstring')
# With a scope
Model.where(something: 'blah').search_by_plaintext(:field, 'searchstring')
```

## Creating your own encryptor

Creating your own encryptor is easy. All you have to do is create a class
under the `CryptKeeper::Provider` namespace, like this:

```ruby
module CryptKeeper
  module Provider
    class MyEncryptor
      def initialize(options = {})
      end

      def encrypt(value)
      end

      def decrypt(value)
      end
    end
  end
end

```

Just require your code and setup your model to use it. Just pass the class name
as a string or an underscored symbol

```ruby
class MyModel < ActiveRecord::Base
  crypt_keeper :field, :other_field, :encryptor => :my_encryptor, :key => 'super_good_password'
end
```
