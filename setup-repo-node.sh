## curl -s -- https://raw.githubusercontent.com/synle/gha-workflows/refs/heads/main/setup-repo-node.sh | bash -s --
# Initialize configuration files
echo "* text=auto eol=lf" > .gitattributes

# dependabot
cat <<EOF > .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: '/'
    schedule:
      interval: monthly
      time: '13:00'
    open-pull-requests-limit: 10
    versioning-strategy: increase
EOF

# prettier
node -e """
const file = '.prettierignore';
const additions = [
  'build',
  '*.bundle.*',
  '*.min.*',
  '.build',
  'coverage',
  'dist',
  'node_modules',
].sort();
const fs = require('fs');

let existing = '';
if (fs.existsSync(file)) {
  existing = fs.readFileSync(file, 'utf8');
}

const lines = [...existing.split(/\r?\n/), ...additions]
  .map(l => l.trim())
  .filter(Boolean);

const unique = [...new Set(lines)].sort();
fs.writeFileSync(file, unique.join('\n') + '\n');
console.log('✅ ' + file + ' consolidated and cleaned.');
"""

# gitignore
node -e """
const file = '.gitignore';
const additions = [
  '*.LICENSE.txt', 
  '*.rej', 
  '*storybook.log', 
  '.cache', 
  '.claude', 
  '.DS_Store', 
  '.env', 
  '.npmrc', 
  '.nyc_output', 
  '.prettier-cache', 
  '.vs-code', 
  'build', 
  'coverage', 
  'DEBUG', 
  'dist', 
  'Error', 
  'node_modules', 
  'npm-debug.log*', 
  'public/vs', 
  'upload', 
  'yarn-debug.log*', 
  'yarn-error.log*', 
].sort();
const fs = require('fs');
let existing = '';
if (fs.existsSync(file)) {
  existing = fs.readFileSync(file, 'utf8');
}

const lines = [...existing.split(/\r?\n/), ...additions]
  .map(l => l.trim())
  .filter(Boolean);

const unique = [...new Set(lines)];
fs.writeFileSync(file, unique.join('\n') + '\n');
console.log('✅ ' + file + ' consolidated and cleaned.');
"""

# Update package.json scripts using Node (No jq required)
node -e """
const file = 'package.json';
const fs = require('fs');
if (fs.existsSync(file)) {
  const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
  pkg.scripts = pkg.scripts || {};
  
  // Use backticks for the value to avoid escaping nightmares
  pkg.scripts.format = \"prettier --write --cache --ignore-unknown --no-error-on-unmatched-pattern --print-width 140 .\";
  if(!pkg?.dependencies?.prettier || !pkg?.devDependencies?.prettier){
    const prettierVersionToUse = pkg?.dependencies?.prettier || pkg?.devDependencies?.prettier || '^3.8.1';
    delete pkg.dependencies.prettier;
    delete pkg.devDependencies.prettier;
    pkg.devDependencies.prettier = prettierVersionToUse;
  }
  
  fs.writeFileSync(file, JSON.stringify(pkg, null, 2) + '\n');
  console.log('✅ '+file+' format script updated.');
} else {
  console.log('❌ '+file+' not found.');
}
"""
