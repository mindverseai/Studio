import React from "react";
import type { FC } from "react";
import type { Metadata } from "next";

export const metadata: Metadata = {
  // Allow the default favicon to be used
};

const Layout: FC<{
  children: React.ReactNode;
}> = ({ children }) => {
  return (
    <div className="min-w-[300px] h-full pb-[env(safe-area-inset-bottom)]">
      {children}
    </div>
  );
};

export default Layout;
