export type PaymentProvider = "upi_qr" | "razorpay" | "manual";
export type PaymentStatus = "created" | "pending" | "paid" | "failed" | "refunded";

export type Block = {
  id: string;
  name: string;
  organizerName: string;
  organizerPhone: string;
  upiId: string;
  qrImageUrl: string;
  paymentProvider: PaymentProvider;
  razorpayKeyId: string;
  razorpayLink: string;
  isActive: boolean;
};

export type Payment = {
  id: string;
  amount: number;
  blockId: string;
  blockName: string;
  residentName: string;
  email: string;
  phone: string;
  flatNumber: string;
  gotram: string;
  provider: PaymentProvider;
  status: PaymentStatus;
  referenceId: string;
  createdAt: string;
  paidAt: string;
};

export type CmsEntry = {
  id: string;
  section: "event" | "schedule" | "announcement" | "gallery" | "volunteer_role" | "app_setting";
  title: string;
  subtitle: string;
  body: string;
  imageUrl: string;
  label: string;
  color: string;
  startsAt: string;
  venue: string;
  sortOrder: number;
  isPublished: boolean;
};

export type Registration = {
  id: string;
  eventTitle: string;
  participantName: string;
  flatNumber: string;
  ageGroup: string;
  mobile: string;
  status: "new" | "confirmed" | "waitlisted" | "cancelled";
  createdAt: string;
};

export type VolunteerSubmission = {
  id: string;
  name: string;
  flatNumber: string;
  mobile: string;
  roles: string[];
  note: string;
  createdAt: string;
};

export type AuctionBid = {
  id: string;
  itemTitle: string;
  amount: number;
  bidderName: string;
  flatNumber: string;
  mobile: string;
  status: "leading" | "outbid" | "cancelled";
  createdAt: string;
};

export type DashboardData = {
  blocks: Block[];
  payments: Payment[];
  cmsEntries: CmsEntry[];
  registrations: Registration[];
  volunteers: VolunteerSubmission[];
  bids: AuctionBid[];
  totals: {
    collected: number;
    pending: number;
    registrations: number;
    volunteers: number;
  };
};
