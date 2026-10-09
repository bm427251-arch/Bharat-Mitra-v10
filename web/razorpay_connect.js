import React, { useState, useEffect } from 'react';

/**
 * Safe localStorage wrappers to avoid SSR / window undefined errors
 */
export const getSafe = (key, def) => {
  try {
    if (typeof window === 'undefined') return def;
    const v = window.localStorage.getItem(key);
    return v ? JSON.parse(v) : def;
  } catch {
    return def;
  }
};

export const setSafe = (key, val) => {
  try {
    if (typeof window !== 'undefined') {
      window.localStorage.setItem(key, JSON.stringify(val));
    }
  } catch {}
};

/**
 * RazorpayConnectForm Component
 * Prevents Gemini Flash internal errors and hydration mismatches.
 */
export default function RazorpayConnectForm() {
  const [mounted, setMounted] = useState(false);
  const [formData, setFormData] = useState({
    keyId: '',
    keySecret: '',
    merchantName: '',
    upiId: '',
  });
  const [keyError, setKeyError] = useState('');
  const [toastMessage, setToastMessage] = useState('');

  // 1. Mount check to prevent SSR / early render localStorage crashes
  useEffect(() => {
    setMounted(true);
  }, []);

  // 2. Load stored config safely after mount
  useEffect(() => {
    if (!mounted) return;
    const saved = getSafe('razorpay_config', {
      keyId: '',
      keySecret: '',
      merchantName: 'Bharat Mitra Infotech',
      upiId: 'bharatmitra@razorpay',
    });
    setFormData(saved);
  }, [mounted]);

  // Loading skeleton when !mounted
  if (!mounted) {
    return (
      <div style={{ padding: '24px', background: '#121212', borderRadius: '12px', color: '#888' }}>
        <div style={{ height: '24px', width: '200px', background: '#222', borderRadius: '4px', marginBottom: '16px' }} />
        <div style={{ height: '40px', width: '100%', background: '#1a1a1a', borderRadius: '6px', marginBottom: '12px' }} />
        <div style={{ height: '40px', width: '100%', background: '#1a1a1a', borderRadius: '6px', marginBottom: '12px' }} />
        <div style={{ height: '40px', width: '120px', background: '#222', borderRadius: '6px' }} />
      </div>
    );
  }

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));

    if (name === 'keyId') {
      const trimmed = value.trim();
      if (trimmed.length > 0 && !trimmed.startsWith('rzp_live_') && !trimmed.startsWith('rzp_test_')) {
        setKeyError('Key ID must start with "rzp_live_" or "rzp_test_"');
      } else {
        setKeyError('');
      }
    }
  };

  const handleSave = (e) => {
    e.preventDefault();
    const trimmedKey = formData.keyId.trim();

    // Validate without throwing error
    if (!trimmedKey.startsWith('rzp_live_') && !trimmedKey.startsWith('rzp_test_')) {
      setKeyError('Key ID must start with "rzp_live_" or "rzp_test_"');
      return;
    }

    setSafe('razorpay_config', formData);
    setToastMessage('Razorpay credentials saved securely!');
    setTimeout(() => setToastMessage(''), 4000);
  };

  return (
    <div style={{ maxWidth: '480px', margin: '20px auto', padding: '24px', background: '#181818', borderRadius: '14px', border: '1px solid #333', color: '#fff', fontFamily: 'system-ui, sans-serif' }}>
      <h2 style={{ fontSize: '18px', fontWeight: 'bold', marginBottom: '6px', color: '#FF9933' }}>
        Razorpay Connect Setup
      </h2>
      <p style={{ fontSize: '12px', color: '#aaa', marginBottom: '20px' }}>
        Connect your direct merchant gateway for instant payouts & QR code settlements.
      </p>

      {toastMessage && (
        <div style={{ background: '#138808', color: '#fff', padding: '10px 14px', borderRadius: '8px', marginBottom: '16px', fontSize: '13px', fontWeight: '500' }}>
          ✓ {toastMessage}
        </div>
      )}

      <form onSubmit={handleSave}>
        <div style={{ marginBottom: '14px' }}>
          <label style={{ display: 'block', fontSize: '12px', marginBottom: '4px', color: '#ddd' }}>
            Razorpay Key ID (Live / Test) *
          </label>
          <input
            type="text"
            name="keyId"
            value={formData.keyId}
            onChange={handleChange}
            placeholder="rzp_live_... or rzp_test_..."
            style={{
              width: '100%',
              padding: '10px 12px',
              borderRadius: '8px',
              border: keyError ? '1px solid #ff4444' : '1px solid #444',
              background: '#222',
              color: '#fff',
              fontSize: '13px',
              boxSizing: 'border-box',
            }}
          />
          {keyError && (
            <span style={{ display: 'block', color: '#ff6b6b', fontSize: '11px', marginTop: '4px' }}>
              {keyError}
            </span>
          )}
        </div>

        <div style={{ marginBottom: '14px' }}>
          <label style={{ display: 'block', fontSize: '12px', marginBottom: '4px', color: '#ddd' }}>
            Razorpay Key Secret *
          </label>
          <input
            type="password"
            name="keySecret"
            value={formData.keySecret}
            onChange={handleChange}
            placeholder="Enter Key Secret"
            style={{
              width: '100%',
              padding: '10px 12px',
              borderRadius: '8px',
              border: '1px solid #444',
              background: '#222',
              color: '#fff',
              fontSize: '13px',
              boxSizing: 'border-box',
            }}
          />
        </div>

        <div style={{ marginBottom: '14px' }}>
          <label style={{ display: 'block', fontSize: '12px', marginBottom: '4px', color: '#ddd' }}>
            Merchant Business Name
          </label>
          <input
            type="text"
            name="merchantName"
            value={formData.merchantName}
            onChange={handleChange}
            placeholder="Bharat Mitra Infotech"
            style={{
              width: '100%',
              padding: '10px 12px',
              borderRadius: '8px',
              border: '1px solid #444',
              background: '#222',
              color: '#fff',
              fontSize: '13px',
              boxSizing: 'border-box',
            }}
          />
        </div>

        <div style={{ marginBottom: '20px' }}>
          <label style={{ display: 'block', fontSize: '12px', marginBottom: '4px', color: '#ddd' }}>
            Linked UPI ID for QR Payouts
          </label>
          <input
            type="text"
            name="upiId"
            value={formData.upiId}
            onChange={handleChange}
            placeholder="bharatmitra@razorpay"
            style={{
              width: '100%',
              padding: '10px 12px',
              borderRadius: '8px',
              border: '1px solid #444',
              background: '#222',
              color: '#fff',
              fontSize: '13px',
              boxSizing: 'border-box',
            }}
          />
        </div>

        <button
          type="submit"
          style={{
            width: '100%',
            padding: '12px',
            background: '#FF9933',
            color: '#000',
            border: 'none',
            borderRadius: '8px',
            fontWeight: 'bold',
            fontSize: '14px',
            cursor: 'pointer',
          }}
        >
          Save Configuration
        </button>
      </form>
    </div>
  );
}
