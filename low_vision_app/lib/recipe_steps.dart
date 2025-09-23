from recipe_scrapers import scrape_me

scraper = scrape_me('https://example.com/recipe')
print(scraper.title())
print(scraper.ingredients())
print(scraper.instructions())
