import Link from 'next/link';

/**
 * Navigation component with links to main pages
 */
export default function Navigation() {
  // Navigation links
  const links = [
    { name: 'Home', href: '/' },
    { name: 'About', href: '/about' },
    { name: 'Features', href: '/features' },
  ];
  
  return (
    <nav className="bg-white border-b py-4 mb-8">
      <div className="max-w-4xl mx-auto px-4">
        <div className="flex items-center justify-between">
          <div className="flex-shrink-0">
            <span className="text-lg font-bold">🧊 ICE WebApp</span>
          </div>
          <div className="flex space-x-6">
            {links.map((link) => (
              <Link
                key={link.name}
                href={link.href}
                className="text-sm font-medium text-gray-600 hover:text-blue-600"
              >
                {link.name}
              </Link>
            ))}
          </div>
        </div>
      </div>
    </nav>
  );
} 