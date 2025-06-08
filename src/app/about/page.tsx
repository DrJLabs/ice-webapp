export default function About() {
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">About ICE WebApp</h1>
        <p className="text-xl text-gray-600 mb-8">
          Learn more about our project and mission
        </p>
        
        <div className="prose max-w-none">
          <p>
            ICE WebApp is a cutting-edge web application built with the latest technologies and best practices.
            Our mission is to demonstrate how modern web applications can be built using Next.js, React, and TypeScript.
          </p>
          
          <h2>Our Team</h2>
          <p>
            Our team consists of experienced developers who are passionate about creating high-quality web applications.
          </p>
          
          <h2>Technology Stack</h2>
          <ul>
            <li><strong>Next.js</strong> - For server-side rendering and routing</li>
            <li><strong>React</strong> - For building user interfaces</li>
            <li><strong>TypeScript</strong> - For type safety and better developer experience</li>
            <li><strong>Tailwind CSS</strong> - For rapid UI development</li>
          </ul>
        </div>
      </div>
    </main>
  )
} 