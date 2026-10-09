/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useEffect, useRef, useState } from 'react';
import { MapPin, Navigation, AlertCircle, RefreshCw } from 'lucide-react';

interface MapViewProps {
  center?: [number, number]; // [lat, lng]
  zoom?: number;
  className?: string;
  markers?: Array<{
    lat: number;
    lng: number;
    title?: string;
  }>;
}

export const MapView: React.FC<MapViewProps> = ({
  center = [22.5726, 88.3639], // Default Kolkata center
  zoom = 13,
  className = 'w-full h-full min-h-[300px]',
  markers = []
}) => {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<any>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Mappls Web SDK Key loaded exclusively from environment variable
  const mapplsKey = import.meta.env.VITE_MAPPLS_KEY || '';

  useEffect(() => {
    if (!mapplsKey) {
      setLoadError('VITE_MAPPLS_KEY is not defined in environment variables.');
      setIsLoading(false);
      return;
    }

    let isMounted = true;
    const scriptId = 'mappls-sdk-script';

    const initializeMap = () => {
      if (!isMounted || !mapContainerRef.current) return;

      const mapplsGlobal = (window as any).mappls;
      if (!mapplsGlobal || typeof mapplsGlobal.Map !== 'function') {
        setLoadError('Mappls SDK loaded, but Map constructor is not available.');
        setIsLoading(false);
        return;
      }

      try {
        if (!mapInstanceRef.current) {
          // Initialize Mappls Vector Map
          mapInstanceRef.current = new mapplsGlobal.Map(mapContainerRef.current, {
            center: [center[0], center[1]],
            zoom: zoom,
            zoomControl: true,
            hybrid: false,
            search: false,
          });

          // Add Markers if provided
          markers.forEach((m) => {
            if (typeof mapplsGlobal.Marker === 'function') {
              new mapplsGlobal.Marker({
                map: mapInstanceRef.current,
                position: { lat: m.lat, lng: m.lng },
                fitbounds: false,
                popupHtml: m.title ? `<div style="padding:4px;font-size:12px;">${m.title}</div>` : undefined
              });
            }
          });
        }
        setIsLoading(false);
      } catch (err: any) {
        setLoadError(err?.message || 'Error initializing Mappls Map.');
        setIsLoading(false);
      }
    };

    // Check if script is already present
    let scriptElement = document.getElementById(scriptId) as HTMLScriptElement | null;

    if (!scriptElement) {
      scriptElement = document.createElement('script');
      scriptElement.id = scriptId;
      scriptElement.src = `https://apis.mappls.com/advancedmaps/api/${mapplsKey}/map_sdk?layer=vector&v=3.0`;
      scriptElement.async = true;
      scriptElement.defer = true;

      scriptElement.onload = () => {
        initializeMap();
      };

      scriptElement.onerror = () => {
        if (isMounted) {
          setLoadError('Failed to load Mappls MapmyIndia SDK script from apis.mappls.com.');
          setIsLoading(false);
        }
      };

      document.head.appendChild(scriptElement);
    } else if ((window as any).mappls) {
      initializeMap();
    } else {
      scriptElement.addEventListener('load', initializeMap);
    }

    return () => {
      isMounted = false;
      if (mapInstanceRef.current && typeof mapInstanceRef.current.remove === 'function') {
        try {
          mapInstanceRef.current.remove();
        } catch (_) {}
        mapInstanceRef.current = null;
      }
    };
  }, [mapplsKey, center, zoom]);

  if (!mapplsKey || loadError) {
    return (
      <div className={`relative flex flex-col items-center justify-center p-6 bg-slate-900 border border-slate-800 rounded-2xl text-center overflow-hidden ${className}`}>
        <div className="absolute inset-0 bg-radial from-amber-500/10 via-transparent to-transparent pointer-events-none" />
        <div className="p-3 bg-amber-500/10 rounded-2xl border border-amber-500/20 text-amber-400 mb-3">
          <Navigation className="w-8 h-8 animate-pulse" />
        </div>
        <h4 className="text-sm font-bold text-white mb-1">Mappls MapmyIndia Vector SDK</h4>
        <p className="text-xs text-slate-400 max-w-sm mb-3">
          {loadError || 'Waiting for Mappls configuration...'}
        </p>
        <div className="flex items-center gap-2 text-[11px] font-mono bg-slate-950 px-3 py-1.5 rounded-lg border border-slate-800 text-slate-300">
          <MapPin className="w-3.5 h-3.5 text-emerald-400" />
          <span>Coordinates: {center[0].toFixed(4)}°N, {center[1].toFixed(4)}°E (Kolkata)</span>
        </div>
      </div>
    );
  }

  return (
    <div className={`relative rounded-2xl overflow-hidden border border-slate-800 bg-slate-950 ${className}`}>
      {isLoading && (
        <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-slate-950/80 backdrop-blur-xs text-amber-400 gap-2">
          <RefreshCw className="w-6 h-6 animate-spin" />
          <span className="text-xs font-medium text-slate-300">Loading Mappls Vector Map...</span>
        </div>
      )}
      <div ref={mapContainerRef} className="w-full h-full min-h-[300px]" />
    </div>
  );
};

export default MapView;
