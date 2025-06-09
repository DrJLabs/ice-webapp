/** @type {import('next').NextConfig} */
const nextConfig = {
  eslint: {
    // Only run ESLint on Next.js app directories during production builds
    dirs: ['src', 'pages', 'components', 'lib', 'utils'],
    // Ignore scripts directory during builds  
    ignoreDuringBuilds: false,
  },
  experimental: {
    optimizePackageImports: ['lucide-react'],
    turbo: {
      rules: {
        '*.svg': {
          loaders: ['@svgr/webpack'],
          as: '*.js',
        },
      },
    },
  },
  poweredByHeader: false,
}

module.exports = nextConfig
