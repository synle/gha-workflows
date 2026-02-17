echo '''
* text=auto eol=lf
''' > .gitattributes

echo '''
*.min.*
.build
dist
*.bundle.*
''' > .prettierignore

echo '''
*.LICENSE.txt
*.rej
*storybook.log
.cache
.claude
.DS_Store
.env
.npmrc
.nyc_output
.prettier-cache
.vs-code
build
coverage
DEBUG
dist
Error
node_modules
npm-debug.log*
package-lock.json
public/vs
upload
yarn-debug.log*
yarn-error.log*
yarn.lock
''' >> .gitignore

# Deduplicate removals (Preserving Order)
node -e """
const fs = require('fs');
const file = '.gitignore';
if (fs.existsSync(file)) {
  const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
  const unique = [...new Set(lines)];
  fs.writeFileSync(file, unique.join('\n'));
  console.log(`✅ ${file} cleaned (duplicates removed).`);
}
"""


# We'll use a temporary file to ensure the write is successful
if command -v jq >/dev/null 2>&1; then
  jq '.scripts.format = "prettier --write --ignore-unknown --cache '\''**/*.{js,jsx,ts,tsx,mjs,cjs,json,html,css,scss,less,md,yml,yaml,graphql,vue,xml}'\''"' package.json > package.json.tmp && mv package.json.tmp package.json
  echo "✅ package.json scripts updated."
else
  echo "❌ Error: jq is not installed. Please install it to update package.json automatically."
fi
