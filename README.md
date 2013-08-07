#Viaggio
##It's Italian for 'Travel'

Viaggio is a Ruby on Rails web app that helps you showcase your favorite trips and adventures in a fun and immersive way. Photos are intelligently displayed on a map using the time and location metadata.

Scrolling through photos pans the map accordingly, while the overall color scheme gradually changes to match the current photo.

Site built in Rails. Login with Facebook OAuth. Photos retrieved with Facebook and Instragram APIs. Manual photo upload with javascript and Imgur API. Maps with Google maps. Dynamically drawn lines with D3. Color palettes extracted using Miro gem.

Demo:

<http://viagg.io>


Contributors:
- [Tyler Hartland](https://github.com/th7)
- [Chris Laubacher](https://github.com/claubacher)
- [Jimmi Carney](https://github.com/ayoformayo)
- [Patrick Moody](https://github.com/patmood)



##Development

To run this app you'll need:

Ruby 1.9.3

Postgresql 9.2+

Rails 3.2.13



##Install

- Fork the repo and clone the files onto your local machine:

      $ git clone https://github.com/th7/journey-tracker.git

- Navigate to the application directory in terminal and run **bundle install** to gather the required gems:

      $ bundle install

- You'll likely need to edit those settings for your local machine. Now you need to create and set up the database:

      $ rake db:setup

- Launch the application server:

      $ rails server

- Open a broswer and navigate to localhost:3000

- Relive your journey!
