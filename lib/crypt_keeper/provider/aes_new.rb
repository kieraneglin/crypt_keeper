require 'aes'
require 'AESCrypt'
require 'armor'

module CryptKeeper
  module Provider
    class AesNew
      include CryptKeeper::Helper::DigestPassphrase

      # Public: The encryption key
      attr_accessor :key

      # Public: Initializes the class
      #
      #   options - A hash of options. :key and :salt are required
      def initialize(options = {})
        @key = digest_passphrase(options[:key], options[:salt])
      end

      # Public: Encrypt a string
      #
      # Note: nil and empty strings are not encryptable with AES.
      # When they are encountered, the orignal value is returned.
      # Otherwise, returns the encrypted string
      #
      # Returns a String
      def encrypt(value)
        AESCrypt.encrypt(value, key, {iv: '4358eccd66f96e36c0c35420f619f0ced2e2c6d20556df2ba7af26761dab7fe7f0d676520176f11dac8c0e22d64ef4e195bc7406bf5a0c211c59bc2a196ae6a8'})
      end

      # Public: Decrypt a string
      #
      # Note: nil and empty strings are not encryptable with AES (and thus cannot be decrypted).
      # When they are encountered, the orignal value is returned.
      # Otherwise, returns the decrypted string
      #
      # Returns a String
      def decrypt(value)
        AESCrypt.decrypt(value, key)
      end

      # Public: Search for a record
      #
      # record   - An ActiveRecord collection
      # field    - The field to search
      # criteria - A string to search with
      #
      # Returns an Enumerable
      def search(records, field, criteria)
        records.select { |record| record[field] == criteria }
      end
    end
  end
end
