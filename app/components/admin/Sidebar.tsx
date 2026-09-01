"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  HomeIcon,
  UsersIcon,
  CalendarIcon,
  DocumentTextIcon,
  CreditCardIcon,
  Cog6ToothIcon,
  Bars3Icon,
  XMarkIcon,
  QrCodeIcon
} from "@heroicons/react/24/outline";
import { useState } from "react";
import { logoutAdmin } from "@/app/admin/actions";

const navigation = [
  { name: "Dashboard", href: "/admin", icon: HomeIcon },
  { name: "Members", href: "/admin/members", icon: UsersIcon },
  { name: "Events", href: "/admin/events", icon: CalendarIcon },
  { name: "PWA Content", href: "/admin/content", icon: DocumentTextIcon },
  { name: "Blocks & QR", href: "/admin/blocks", icon: QrCodeIcon },
  { name: "Payments", href: "/admin/payments", icon: CreditCardIcon },
  { name: "Registrations", href: "/admin/registrations", icon: UsersIcon },
  { name: "Auction", href: "/admin/auction", icon: DocumentTextIcon },
  { name: "Settings", href: "/admin/settings", icon: Cog6ToothIcon },
];

export function Sidebar() {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <>
      {/* Mobile top bar */}
      <div className="lg:hidden flex items-center justify-between bg-zinc-900 px-4 py-3 sm:px-6">
        <div className="flex items-center gap-2">
          <div className="grid size-8 place-items-center rounded-md bg-white text-xs font-bold text-zinc-900">
            BT
          </div>
          <span className="text-white font-semibold">BT AVANI</span>
        </div>
        <button
          onClick={() => setMobileMenuOpen(true)}
          className="text-zinc-300 hover:text-white"
        >
          <Bars3Icon className="h-6 w-6" />
        </button>
      </div>

      {/* Mobile sidebar overlay */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-50 flex lg:hidden">
          <div className="fixed inset-0 bg-black/80" onClick={() => setMobileMenuOpen(false)} />
          <div className="relative flex w-full max-w-xs flex-1 flex-col bg-zinc-900 pb-4 pt-5">
            <div className="absolute right-0 top-0 -mr-12 pt-2">
              <button
                className="ml-1 flex h-10 w-10 items-center justify-center rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                onClick={() => setMobileMenuOpen(false)}
              >
                <XMarkIcon className="h-6 w-6 text-white" />
              </button>
            </div>
            <div className="flex shrink-0 items-center px-4 gap-3">
              <div className="grid size-10 place-items-center rounded-lg bg-white text-sm font-bold text-zinc-900">
                BT
              </div>
              <span className="text-white font-bold text-lg">BT AVANI Admin</span>
            </div>
            <div className="mt-8 h-0 flex-1 overflow-y-auto px-2">
              <nav className="flex flex-col gap-1">
                {navigation.map((item) => {
                  const isActive = pathname === item.href;
                  return (
                    <Link
                      key={item.name}
                      href={item.href}
                      onClick={() => setMobileMenuOpen(false)}
                      className={`group flex items-center gap-x-3 rounded-md p-2 text-sm font-semibold leading-6 ${
                        isActive
                          ? "bg-zinc-800 text-white"
                          : "text-zinc-400 hover:bg-zinc-800 hover:text-white"
                      }`}
                    >
                      <item.icon className="h-6 w-6 shrink-0" />
                      {item.name}
                    </Link>
                  );
                })}
              </nav>
            </div>
            <div className="px-4 mt-auto border-t border-zinc-800 pt-4">
               <form action={logoutAdmin}>
                 <button className="text-zinc-400 hover:text-white text-sm font-semibold w-full text-left">
                   Sign out
                 </button>
               </form>
            </div>
          </div>
        </div>
      )}

      {/* Desktop sidebar */}
      <div className="hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-72 lg:flex-col">
        <div className="flex grow flex-col gap-y-5 overflow-y-auto bg-zinc-900 px-6 pb-4">
          <div className="flex h-16 shrink-0 items-center gap-3">
            <div className="grid size-8 place-items-center rounded-lg bg-white text-sm font-bold text-zinc-900">
              BT
            </div>
            <span className="text-white font-bold text-lg tracking-tight">BT AVANI</span>
          </div>
          <nav className="flex flex-1 flex-col">
            <ul role="list" className="flex flex-1 flex-col gap-y-7">
              <li>
                <ul role="list" className="-mx-2 space-y-1">
                  {navigation.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                      <li key={item.name}>
                        <Link
                          href={item.href}
                          className={`group flex items-center gap-x-3 rounded-md p-2 text-sm font-semibold leading-6 transition-colors ${
                            isActive
                              ? "bg-zinc-800 text-white"
                              : "text-zinc-400 hover:bg-zinc-800 hover:text-white"
                          }`}
                        >
                          <item.icon className="h-6 w-6 shrink-0" />
                          {item.name}
                        </Link>
                      </li>
                    );
                  })}
                </ul>
              </li>
              <li className="mt-auto">
                <form action={logoutAdmin}>
                  <button className="group -mx-2 flex gap-x-3 rounded-md p-2 text-sm font-semibold leading-6 text-zinc-400 hover:bg-zinc-800 hover:text-white w-full text-left transition-colors">
                    <Cog6ToothIcon className="h-6 w-6 shrink-0" />
                    Sign out
                  </button>
                </form>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </>
  );
}
