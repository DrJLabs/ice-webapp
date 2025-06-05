/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: ['lucide-react'],
  },
  swcMinify: true,
  poweredByHeader: false,
}

module.exports = nextConfig
