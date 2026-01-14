import React, { useState, useEffect } from 'react';
import { Mail, MessageCircle, Save, Loader2 } from 'lucide-react';

// Use relative URL so it works with the proxy or same-origin
const API_URL = '/api/config';

function App() {
    const [formData, setFormData] = useState({
        whatsappToken: '',
        mailUser: '',
        mailPassword: '', // Added password just in case, though user only asked for user/mailserver
        mailServer: ''
    });
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [status, setStatus] = useState(null);

    useEffect(() => {
        fetchConfig();
    }, []);

    const fetchConfig = async () => {
        try {
            const res = await fetch(API_URL);
            if (res.ok) {
                const data = await res.json();
                setFormData(prev => ({ ...prev, ...data }));
            }
        } catch (err) {
            console.error("Failed to fetch config", err);
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setSaving(true);
        setStatus(null);

        try {
            const res = await fetch(API_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData)
            });

            if (res.ok) {
                setStatus({ type: 'success', msg: 'Configuration saved successfully!' });
            } else {
                throw new Error('Save failed');
            }
        } catch (err) {
            setStatus({ type: 'error', msg: 'Failed to save settings. Please try again.' });
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return <div className="glass-panel" style={{ textAlign: 'center' }}>Loading...</div>;
    }

    return (
        <div className="glass-panel">
            <h1>System Config</h1>
            <p className="subtitle">Configure integration settings for WhatsApp and Email services.</p>

            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label>
                        <MessageCircle size={16} style={{ display: 'inline', verticalAlign: 'text-bottom', marginRight: '6px' }} />
                        WhatsApp Token / API Key
                    </label>
                    <input
                        type="text"
                        name="whatsappToken"
                        value={formData.whatsappToken}
                        onChange={handleChange}
                        placeholder="e.g. WA_AUTH_TOKEN_123"
                    />
                </div>

                <div className="form-group">
                    <label>
                        <Mail size={16} style={{ display: 'inline', verticalAlign: 'text-bottom', marginRight: '6px' }} />
                        Mail Server Host
                    </label>
                    <input
                        type="text"
                        name="mailServer"
                        value={formData.mailServer}
                        onChange={handleChange}
                        placeholder="e.g. smtp.gmail.com"
                    />
                </div>

                <div className="form-group">
                    <label>
                        Mail User
                    </label>
                    <input
                        type="text"
                        name="mailUser"
                        value={formData.mailUser}
                        onChange={handleChange}
                        placeholder="e.g. user@company.com"
                    />
                </div>

                <div className="form-group">
                    <label>Mail Password / App Key</label>
                    <input
                        type="password"
                        name="mailPassword"
                        value={formData.mailPassword}
                        onChange={handleChange}
                        placeholder="********"
                    />
                </div>

                <button type="submit" disabled={saving}>
                    {saving ? (
                        <>
                            <span className="loading-spinner"></span> Saving...
                        </>
                    ) : (
                        <>
                            <Save size={18} style={{ display: 'inline', verticalAlign: 'bottom', marginRight: '8px' }} />
                            Save Configuration
                        </>
                    )}
                </button>

                {status && (
                    <div className={`status-msg ${status.type}`}>
                        {status.msg}
                    </div>
                )}
            </form>
        </div>
    );
}

export default App;
