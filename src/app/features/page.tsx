export default function Features() {
  // Feature cards data
  const features = [
    {
      title: "Server-Side Rendering",
      description: "Pre-render pages on the server for better performance and SEO."
    },
    {
      title: "TypeScript Support",
      description: "Full type safety for better developer experience and fewer bugs."
    },
    {
      title: "Responsive Design",
      description: "Fully responsive layouts that work on any device size."
    },
    {
      title: "Accessibility",
      description: "Built with a11y in mind, following WCAG guidelines."
    },
    {
      title: "Fast Refresh",
      description: "Instant feedback during development with hot module replacement."
    },
    {
      title: "SEO Friendly",
      description: "Built-in SEO optimization with meta tags and structured data."
    }
  ];

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">Features</h1>
        <p className="text-xl text-gray-600 mb-8">
          Explore the key features of ICE WebApp
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {features.map((feature, index) => (
            <div key={index} className="p-6 border rounded-lg">
              <h2 className="text-2xl font-semibold mb-2">{feature.title}</h2>
              <p>{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </main>
  )
} 