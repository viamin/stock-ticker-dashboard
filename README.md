# README

This is the dashboard for the NY Trash Exchange and Trashholder's Lounge

It is used to scrape prices from the Racc Investment Management project website and display them on a dashboard. It will also update the prices on an arduino LED based ticker, and allow "hackers" to alter the ticker text if they can figure out how.

## Deployment

The site is hosted on a raspberry pi 4 with a static IP address. To deploy:

```
bundle exec cap production deploy
```

## Credits

Dashboard ticker font is adapted from https://www.fontspace.com/subway-ticker-font-f5621 with some added glyphs ("⏷" & "⏶")
Arduino ticker is based on https://github.com/bigjosh/MacroMarquee (see https://wp.josh.com/2016/05/20/huge-scrolling-arduino-led-sign/ for build info)
