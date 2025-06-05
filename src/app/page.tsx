export default function Home() {
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">🧊 ICE WebApp</h1>
        <p className="text-xl text-gray-600 mb-8">
          AI-optimized web application running on bleeding-edge technology
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Next.js 15</h2>
            <p>App Router with Turbo optimizations</p>
          </div>
          
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">React 19</h2>
            <p>Latest React with concurrent features</p>
          </div>
          
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">TypeScript 5.7</h2>
            <p>Strict mode with latest language features</p>
          </div>
          
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Tailwind CSS</h2>
            <p>Utility-first styling framework</p>
          </div>
        </div>
      </div>
    </main>
  )
}
