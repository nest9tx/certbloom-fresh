'use client';

import Link from 'next/link';
import Image from 'next/image';

interface StaticNavigationProps {
  currentPage?: string;
}

export default function StaticNavigation({ currentPage }: StaticNavigationProps) {
  const getLinkStyle = (page: string) => {
    return currentPage === page
      ? "text-green-900 font-semibold transition-colors"
      : "text-green-700 hover:text-green-900 transition-colors font-medium";
  };

  return (
    <nav className="relative z-10 bg-white/80 backdrop-blur-md border-b border-green-200/50">
      <div className="max-w-7xl mx-auto flex items-center justify-between p-6">
        <Link href="/" className="flex items-center space-x-3 group">
          <div className="w-10 h-10 transition-transform group-hover:scale-105">
            <Image src="/certbloom-logo.svg" alt="CertBloom" width={40} height={40} className="w-full h-full object-contain" />
          </div>
          <div className="text-2xl font-light text-green-800 tracking-wide">CertBloom</div>
        </Link>
        
        <div className="hidden md:flex items-center space-x-8">
          <Link href="/" className={getLinkStyle('home')}>Home</Link>
          <Link href="/features" className={getLinkStyle('features')}>Features</Link>
          <Link href="/pricing" className={getLinkStyle('pricing')}>Pricing</Link>
          <Link href="/about" className={getLinkStyle('about')}>About</Link>
          <Link href="/contact" className={getLinkStyle('contact')}>Contact</Link>
          <Link href="/support" className={getLinkStyle('support')}>Support</Link>
          
          <Link 
            href="/auth" 
            className="px-6 py-2 bg-gradient-to-r from-green-600 to-green-700 text-white rounded-xl hover:from-green-700 hover:to-green-800 transition-all duration-200 shadow-lg hover:shadow-xl transform hover:scale-105"
          >
            Sign In
          </Link>
        </div>
      </div>
    </nav>
  );
}
