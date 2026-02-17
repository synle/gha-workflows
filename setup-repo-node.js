## curl -s -- https://raw.githubusercontent.com/synle/gha-workflows/refs/heads/main/setup-repo-node.js | bash -s --
# 1. Initialize configuration files
echo "* text=auto eol=lf" > .gitattributes

echo """
build
*.bundle.*
*.min.*
.build
coverage
dist
node_modules  
""" >> .prettierignore
# Deduplicate (Preserving Order)
node -e """
const file = '.prettierignore';
const fs = require('fs');
if (fs.existsSync(file)) {
  const content = fs.readFileSync(file, 'utf8');
  const lines = content.split(/\r?\n/);
  const unique = [...new Set(lines)];
  fs.writeFileSync(file, unique.join('\n'));
  console.log('✅ ' + file + ' cleaned (duplicates removed).');
}
"""

echo """*.LICENSE.txt
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
yarn.lock""" >> .gitignore

# Deduplicate (Preserving Order)
node -e """
const file = '.gitignore';
const fs = require('fs');
if (fs.existsSync(file)) {
  const content = fs.readFileSync(file, 'utf8');
  const lines = content.split(/\r?\n/);
  const unique = [...new Set(lines)];
  fs.writeFileSync(file, unique.join('\n'));
  console.log('✅ ' + file + ' cleaned (duplicates removed).');
}
"""

# 3. Update package.json scripts using Node (No jq required)
node -e """
const fs = require('fs');
const file = 'package.json';
if (fs.existsSync(file)) {
  const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
  pkg.scripts = pkg.scripts || {};
  pkg.scripts.format = \"prettier --write --ignore-unknown --cache '**/*.{js,jsx,ts,tsx,mjs,cjs,json,html,css,scss,less,md,yml,yaml,graphql,vue,xml}'\";
  fs.writeFileSync(file, JSON.stringify(pkg, null, 2) + '\n');
  console.log('✅ package.json format script updated.');
} else {
  console.log('❌ Error: package.json not found.');
}
"""
