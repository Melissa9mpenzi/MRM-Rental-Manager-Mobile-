import React, { useEffect, useState } from "react";
import api from "../../services/api";

const TenantDashboard = () => {
  const [leaseData, setLeaseData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboard = async () => {
      try {
        const res = await api.get("/tenant/my-lease");
        setLeaseData(res.data.data);
      } catch (err) {
        console.error("Failed to load lease info", err);
      } finally {
        setLoading(false);
      }
    };
    fetchDashboard();
  }, []);

  if (loading)
    return (
      <div className="p-8 text-center dark:text-slate-400">
        Loading your rental portal...
      </div>
    );

  return (
    <div className="max-w-4xl mx-auto p-6 dark:bg-slate-950 transition-colors">
      <header className="mb-8">
        <h1 className="text-2xl font-bold text-slate-800 dark:text-white">
          My Rental Portal
        </h1>
        <p className="text-slate-500 dark:text-slate-400">
          Welcome back, {leaseData?.tenant?.full_name}
        </p>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Rent Card */}
        <div className="bg-white dark:bg-slate-900 p-6 rounded-2xl border border-slate-100 dark:border-slate-800 shadow-sm">
          <h3 className="text-xs font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider mb-4">
            Current Lease
          </h3>
          {leaseData?.lease ? (
            <>
              <div className="flex justify-between items-end mb-4">
                <div>
                  <p className="text-3xl font-bold text-emerald-600 dark:text-emerald-400">
                    UGX {leaseData.lease.monthly_rent?.toLocaleString()}
                  </p>
                  <p className="text-sm text-slate-500">Due monthly</p>
                </div>
                <span className="bg-orange-100 text-orange-600 px-3 py-1 rounded-full text-xs font-bold">
                  {leaseData.lease.status?.toUpperCase()}
                </span>
              </div>
              <button className="w-full bg-emerald-600 text-white py-3 rounded-xl font-bold hover:bg-emerald-700 transition">
                Pay Online
              </button>
            </>
          ) : (
            <p className="text-slate-500 italic">
              No active lease record found.
            </p>
          )}
        </div>

        {/* Property Info */}
        <div className="bg-slate-900 dark:bg-black text-white p-6 rounded-2xl shadow-sm border dark:border-slate-800">
          <h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-4">
            Property Details
          </h3>
          <p className="text-lg font-semibold">
            {leaseData?.property?.name || "N/A"}
          </p>
          <p className="text-slate-400 dark:text-slate-500 text-sm">
            {leaseData?.property?.address}
          </p>
          <div className="mt-4 pt-4 border-t border-slate-800 dark:border-slate-700">
            <p className="text-sm">
              Unit:{" "}
              <span className="text-emerald-400">
                {leaseData?.unit?.unit_number}
              </span>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TenantDashboard;
